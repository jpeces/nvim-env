# nvim-env
Docker image intended to serve as an environment for working with nvim configuration files. Deploy an environment with a custom external mount volume to store configuration files without altering the main one.

```bash
Usage:  setup-env [OPTIONS]

Options:
      --name    string      Assign a name to the container (default: nvim-env)
  -i, --image   string      Name of the target docker image (default: nvim-env)
  -u, --user    string      User name used to build and access to the container (default: nvim)
  -d, --config  string      Host directory to mount as config (default: ${HOME}/.config/nvim)
  -b, --build               Force Docker image build stage (default: false)
  -h  --help                Show this help
```
