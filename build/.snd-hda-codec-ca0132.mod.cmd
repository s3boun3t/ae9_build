savedcmd_snd-hda-codec-ca0132.mod := printf '%s\n'   ca0132.o | awk '!x[$$0]++ { print("./"$$0) }' > snd-hda-codec-ca0132.mod
