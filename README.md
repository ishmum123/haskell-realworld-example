# conduit-server

A Haskell implementation of [realworld.io](https://realworld.io)

## Tech stack

- RIO for an alternative Prelude
- Rel8 for interacting with PostgreSQL databases
- Servant for web api implementation
- Dhall for configuration
- cryptonite for Cryptography
- PostgreSQL

## Get start

```bash
git clone https://github.com/nodew/haskell-realworld-example.git
cd haskell-realworld-example

cat conduit.dhall.tpl > conduit.dhall

stack build
stack exec conduit-server-exe
```
