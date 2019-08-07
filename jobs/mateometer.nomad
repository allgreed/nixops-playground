job "mateometer" {
  datacenters = ["dc1"]

  group "mateometer" {
    count = 1

    task "mateometer" {
      driver = "docker"

      service {
        address_mode = "host"
        tags = ["leader", "mysql"]

        check {
          type     = "tcp"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }

      config {
        image = "allgreed/mateometer:preview3"

        network_mode = "host"
      }

      resources {
        cpu    = 100
        memory = 50

        network {
            port "http" {
                static = "8000"
            }
        }
      }
    }
  }
}
