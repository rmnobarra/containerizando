resource "aws_ecrpublic_repository" "containerizando" {

  repository_name = "containerizando"

  catalog_data {
    about_text        = "Imagem muito bacana do projeto containerizando"
    architectures     = ["x86-64"]
    description       = "Imagem Containerizando"
    operating_systems = ["Linux"]
    usage_text        = "TO DO"
  }
}