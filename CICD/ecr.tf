resource "aws_ecrpublic_repository" "ecr1" {
  #provider = aws.us_east_1

  repository_name = "geoapp"

  catalog_data {
    about_text        = "About Text"
    architectures     = ["ARM"]
    description       = "cicd repo"
  #  logo_image_blob   = filebase64(image.png)
    operating_systems = ["Linux"]
    usage_text        = "Usage Text"
  }
}