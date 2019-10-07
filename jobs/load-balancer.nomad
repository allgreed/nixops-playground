job "load-balancer" {
    datacenters = ["dc1"]
    type = "system"

    group "fabio"
    {
        task "fabio"
        {
            driver = "docker"
            config
            {
                image = "fabiolb/fabio"
                network_mode = "host"
            }

            env
            {
                FABIO_PROXY_ADDR = ":80"
                FABIO_UI_COLOR = "purple"
                FABIO_UI_ACCESS = "ro"
                FABIO_UI_TITLE = "elorap"
            }

            resources
            {
                cpu    = 200
                memory = 128
                network
                {
                    port "lb"
                    {
                        static = 80
                    }
                    port "ui"
                    {
                        static = 9998
                    }
                }
            }
        }
    }
}
