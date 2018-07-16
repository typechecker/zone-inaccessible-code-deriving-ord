# Inaccessible code in a pattern with constructor

Reproduction of the reported error;

```
> stack build flight-zone --ghc-options=-ddump-deriv
...
/.../zone/library/Flight/Zone.hs:25:1: error:
    • Couldn't match type ‘OpenDistance’ with ‘CourseLine’
      Inaccessible code in
        a pattern with constructor:
          Point :: forall a. (Eq a, Ord a) => Zone CourseLine a,
        in a case alternative
    • In the pattern: Point {}
      In a case alternative: Point {} -> GT
      In the expression:
        case b of
          Point {} -> GT
          Vector -> EQ
          _ -> LT
      When typechecking the code for ‘compare’
        in a derived instance for ‘Ord (Zone k a)’:
        To see the code I am typechecking, use -ddump-deriv
   |
25 | deriving instance (Eq a, Ord a) => Ord (Zone k a)
   | ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

/.../zone/library/Flight/Zone.hs:25:1: error:
    • Couldn't match type ‘OpenDistance’ with ‘CourseLine’
      Inaccessible code in
        a pattern with constructor:
          Point :: forall a. (Eq a, Ord a) => Zone CourseLine a,
        in a case alternative
    • In the pattern: Point {}
      In a case alternative: Point {} -> False
      In the expression:
        case b of
          Point {} -> False
          Vector -> False
          _ -> True
      When typechecking the code for ‘<’
        in a derived instance for ‘Ord (Zone k a)’:
        To see the code I am typechecking, use -ddump-deriv
   |
25 | deriving instance (Eq a, Ord a) => Ord (Zone k a)
   | ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
```

The `*.cabal` file is ready to go but if you want to tweak any of the `*.dhall`
files from which it is generated then install the dhall tooling with;

```
> stack install dhall hpack-dhall
...
Copied executables to /.../__shake-build:
- dhall
- dhall-format
- dhall-hash
- dhall-repl
- hpack-dhall
```

To generate the `*.cabal` file;

```
> stack exec hpack-dhall -- zone
...
zone/flight-zone.cabal is up-to-date
```
