let
  # Single shared age key. Public key only; the private key lives in Bitwarden
  # and on each machine (see secrets/README.md).
  key = "age18j3acwnuvfevnmh4axs27p0x6ltscl83a6sgjfe3fc8ngly75ckq62ac28";
in
{
  "openroute-token.age".publicKeys = [ key ];
  "cloudflared-token.age".publicKeys = [ key ];
  "forgejo-runner-token.age".publicKeys = [ key ];
}
