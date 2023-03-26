
/*
For the credentials part:
==> Create a ~/.aws/credentials:
[sam-scaleway]
aws_access_key_id=<SCW_ACCESS_KEY>
aws_secret_access_key=<SCW_SECRET_KEY>
region=nl-ams
*/

/*
I was a bit naughty and made the bucket by hand
*/

terraform {
  backend "s3" {
    bucket                      = "sam-terraform-state"
    key                         = "terraform.tfstate"
    region                      = "nl-ams"
    endpoint                    = "https://s3.nl-ams.scw.cloud"
    profile                     = "sam-scaleway"
    skip_credentials_validation = true
    skip_region_validation      = true
  }
}
