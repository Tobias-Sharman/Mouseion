# Conventions

This is my first project of any meaningful size using go and IaC so conventions
are lax and may change as I go.

## Naming

First and foremost namings should be clear and descriptive even if at cost of
length with shortening only for truly explicit and aparent typical naming
fashions.

| What                                                 | Convention | Example                                                 |
| ---------------------------------------------------- | ---------- | -----------------------------------------------------   |
| Directories                                          | kebab-case | `roles/kube-apiserver/`                                 |
| Files                                                | snake_case | `06_control_plane.yml`, `kube_apiserver_service.j2`     |
| Generated certs, keys, kubeconfigs                   | kebab-case | `kube-controller-manager.pem`, `service-account-key.pem`|

*For code related stuff see below.*

The divergence of the naming of generated certs, kets, and kubeconfigs compated
to files is twofold. Firsy to match both clashes with namings of stuff in aws
with dashes vs underscores making both consistency poor and at implementation
much cleaner since there is no need to have machinery to convery - to _. Second
to match the conventions used in learning resources.

This does not apply to Kubernetes' own fixed identity strings (`system:masters`,
`system:kube-proxy`, `kubernetes.default.svc.cluster.local`, etc.) — those are
Kubernetes' reserved convention, and thus are never renamed.

### Code

Naming syntax in code will primarily follow a camelCase for variabel names and
Pascal case for structs. Due to the way go handles function naming with the
first letters capitalisation dictating exporting that naming is therefore in
accordance with that. I am new to go so until I have a style I like I will keep
to my more standard style used for C-like language projects rather that a Python
like one.

## Line Length

Soft-limit of 80, i.e. try to keep code under 80 but when names get long this
becomes difficult.

Hard-limit of 120, unless unreasonable to otherwise do so a 120 line limit
should not be exceeded.

## Linters

Just follow the linters up until what they advise is truly wrong and then, and
only then, use some nolint syntax if possible to express acknoledgement and
that warning is to be deliberately supressed.
