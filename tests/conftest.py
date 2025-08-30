import logging
from contextlib import contextmanager
from os import path as osp

from textwrap import dedent

from infrahouse_core.logging import setup_logging


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
def create_tf_conf(
    tf_dir,
    region,
    management_cidr_block,
    vpc_cidr_block,
    subnets,
    zone_names: list,
    restrict_all_traffic: bool,
    enable_vpc_flow_logs: bool = False,
    test_role_arn: str = None,
):
    config_file = osp.join(tf_dir, "terraform.tfvars")
    try:
        with open(config_file, "w") as fd:
            fd.write(
                dedent(
                    f"""
                    region = "{region}"
                    management_cidr_block = "{management_cidr_block}"
                    vpc_cidr_block = "{vpc_cidr_block}"
                    restrict_all_traffic = {str(restrict_all_traffic).lower()}
                    enable_vpc_flow_logs = {str(enable_vpc_flow_logs).lower()}
                    """
                )
            )
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
                fd.write(
                    dedent(
                        f"""
                        role_arn      = "{test_role_arn}"
                        """
                    )
                )

        LOG.info(
            "Terraform configuration: %s",
            open(osp.join(tf_dir, "terraform.tfvars")).read(),
        )
        yield
    finally:
        pass
        # os.remove(config_file)
