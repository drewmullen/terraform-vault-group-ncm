# Terraform repo template

## TL;DR usage

1. [install pre-commit](https://pre-commit.com/)
2. configure pre-commit: `pre-commit install`
3. install required tools
    - [tflint](https://github.com/terraform-linters/tflint)
    - [trivy](https://trivy.dev/latest/getting-started/)
    - [terraform-docs](https://github.com/terraform-docs/terraform-docs)

## Module Documentation

**Do not manually update README.md after `BEGIN_TF_DOCS`**. `terraform-docs` is used to generate README files. For any instructions an content, please update above the `BEGIN_TF_DOCS` tag then simply run `terraform-docs ./` or allow the `pre-commit` to do so.

## References

[References](./.header.md)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->