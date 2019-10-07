job "mateometer"
{
    datacenters = ["dc1"]

    group "mateometer"
    {
        count = 1

        task "mateometer"
        {
            driver = "docker"
            config
            {
                image = "allgreed/mateometer:preview3"
                network_mode = "host" # TODO: wtf? o.0
                # TODO: add persistant volume
            }

            service
            {
                name = "${JOB}"
                port = "http"
                tags = ["http", "urlprefix-/mate strip=/mate"]

                check
                {
                    type     = "http"
                    path     = "/"
                    interval = "10s"
                    timeout  = "2s"
                }
            }

            resources
            {
                cpu    = 100
                memory = 50

                network
                {
                    # TODO: get rid of this
                    port "http"
                    {
                        static = "8000"
                    }
                }
            }
        }
    }
}
