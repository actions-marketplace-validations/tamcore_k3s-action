# Basic Github Action to deploy K3S

This action deploys a single-node K3S cluster, using Docker as the container runtime.

This was created, as, somehow, none of the existing actions wait for full cluster readyness before progressing. Which in turn resulted in not so nice warnings when I was trying to run my helm chart testing

## Inputs

* `k3s_channel`
  * K3S release channel to follow (see https://update.k3s.io/v1-release/channels)
  * For example, v1.25, v.1.24 and so on
* `k3s_version`
  * Specific K3S version to install
  * Takes precedence over k3s_channel (see https://get.k3s.io/)

## Outputs

* Nothing, as of now. `~/.kube/config` is created by the K3S installer, but that's about it.

## Example usage

```yaml
- uses: tamcore/k3s-action@master
  with:
    # This could also be omitted, as the 'stable' channel is selected by default
    k3s_channel: 'latest'
- run: |
    kubectl get nodes -o wide
    kubectl get pods -A -o wide
```

```yaml
name: CI

on:
  pull_request:
    branches:
      - master
  workflow_dispatch:

jobs:
  ci:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        k3s_channel:
          - v1.23
          - v1.24
          - v1.25
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - uses: tamcore/k3s-action@master
        with:
          k3s_channel: "${{ matrix.k3s_channel }}"

      - name: Do something
        run: |
          kubectl get nodes -o wide
          kubectl get pods -A -o wide
```
