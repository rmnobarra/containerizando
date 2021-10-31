resource postgresql_database "containerizando" {
  name = "containerizando"
  
  depends_on = [
    module.rds
  ] 
}