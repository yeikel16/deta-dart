# CHANGELOG

## 0.0.1-beta

* feat: add methods to interact with DetaBase

## 0.0.2-beta

* rearrange(deta): move `deta` package to `packages` folder
* **BREAKING:** implement `ClientDetaApi` from `client_deta_api`

## 0.0.3

* deps: remove unnecessary dependencies
  * `equeatable`
  * `dio`
  * `meta`

* fix named parameters in `DetaReponse` constructor
* change `client_deta_api` version to 0.0.2

## 0.0.3+1

* rearrange: move everything related to DetaBase to the deta_base file.
* docs: fix broken link [#8](https://github.com/yeikel16/deta-dart/issues/8)
* docs: add warning for the client should only be used on the server side.
