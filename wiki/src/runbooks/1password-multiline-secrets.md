# 1Password: multi-line secrets (keys, certs)

## Problem

Password, text and concealed fields turn line breaks into spaces. A PEM key or an
OpenVPN static key pasted into one comes back from `op read` as a single line and
fails to parse. Note fields keep line breaks but are not concealed.

## Fix

Store the file as an attachment on the item, keeping its original file name.
`op read` resolves attachments by file name:

```fish
op read "op://<vault>/<item>/<filename>"
```

Delete any field with the same name first, or the reference is ambiguous.

## Verify

Compare line counts without printing key material:

```fish
for f in ca.crt user.key; echo $f (op read "op://<vault>/<item>/$f" | wc -l) (wc -l < ~/path/to/$f); end
```

A count of 1 means the line breaks were lost.
