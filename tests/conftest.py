import logging
import os
from contextlib import ExitStack, contextmanager
from os import path as osp
from subprocess import CalledProcessError

from textwrap import dedent
from typing import Iterator

from infrahouse_core.logging import setup_logging
from pytest_infrahouse import terraform_apply

LOG = logging.getLogger()
setup_logging(LOG, debug=True)
TERRAFORM_ROOT_DIR = "test_data"


def update_source(path, module_path):
    lines = open(path).readlines()
    with open(path, "w") as fp:
        for line in lines:
            line = line.replace("%SOURCE%", module_path)
            fp.write(line)


@contextmanager
def terraform_apply_with_retries(
    path: str, max_attempts: int = 3, **kwargs
) -> Iterator[dict]:
    """
    Wrap ``pytest_infrahouse.terraform_apply``, retrying the apply phase.

    Works around transient AWS errors, most notably ``PutBucketReplication``
    failing with ``MissingRequestBodyError`` shortly after bucket creation
    (https://github.com/infrahouse/terraform-aws-s3-bucket/issues/27).
    A failed apply is destroyed by ``terraform_apply`` itself, so every
    attempt starts from a clean slate. Only the apply phase is retried;
    exceptions raised by the test body propagate immediately, and the
    teardown (destroy) runs once via the exit stack.

    :param path: Path to a directory with the terraform root module.
    :type path: str
    :param max_attempts: Total number of apply attempts before giving up.
    :type max_attempts: int
    :param kwargs: Passed through to ``terraform_apply``.
    :return: Context manager yielding the ``terraform_apply`` result.
    :raise CalledProcessError: if the apply fails ``max_attempts`` times.
    """
    with ExitStack() as stack:
        tf_out = None
        for attempt in range(1, max_attempts + 1):
            try:
                tf_out = stack.enter_context(terraform_apply(path, **kwargs))
                break
            except CalledProcessError as err:
                if attempt >= max_attempts:
                    raise
                LOG.warning(
                    "terraform apply attempt %d/%d failed: %s. Retrying...",
                    attempt,
                    max_attempts,
                    err,
                )
        yield tf_out


def _pick_replication_region(region: str) -> str:
    candidates = [
        "us-east-1",
        "us-east-2",
        "us-west-1",
        "us-west-2",
    ]
    return next(r for r in candidates if r != region)


@contextmanager
def create_tf_conf(
    tf_dir,
    region,
    management_cidr_block,
    vpc_cidr_block,
    subnets,
    zone_names: list,
    restrict_all_traffic: bool,
    test_role_arn: str = None,
    keep_after: bool = False,
):
    config_file = osp.join(tf_dir, "terraform.tfvars")
    try:
        with open(config_file, "w") as fd:
            fd.write(dedent(f"""
                    region = "{region}"
                    management_cidr_block = "{management_cidr_block}"
                    vpc_cidr_block = "{vpc_cidr_block}"
                    restrict_all_traffic = {str(restrict_all_traffic).lower()}
                    replication_region = "{_pick_replication_region(region)}"
                    """))
            subnets_fmt = f"subnets = {subnets}"
            fd.write(
                subnets_fmt.format(
                    zone_a=zone_names[0],
                    zone_b=zone_names[1] if len(zone_names) > 1 else zone_names[0],
                    zone_c=(
                        zone_names[2]
                        if len(zone_names) > 2
                        else zone_names[1] if len(zone_names) > 1 else zone_names[0]
                    ),
                )
            )
            if test_role_arn:
                fd.write(dedent(f"""
                        role_arn      = "{test_role_arn}"
                        """))

        LOG.info(
            "Terraform configuration: %s",
            open(osp.join(tf_dir, "terraform.tfvars")).read(),
        )
        yield
    finally:
        if not keep_after:
            os.remove(config_file)
