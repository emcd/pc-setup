# Seat toolchain on login shells.
#
# The harness environment carries ~/.local/bin and ~/.cargo/bin on PATH,
# but /etc/profile assigns PATH unconditionally, so any `bash -lc`
# login shell loses the seat entries. A ~/.profile cannot fix it: the
# seat home is a tmpfs that shadows anything baked into the image.
# /etc/profile.d is image-layer state, read by every login shell, so
# the entries are re-prepended here. $HOME expands at login time to
# the seat's container home.
for d in "${HOME}/.local/bin" "${HOME}/.cargo/bin"; do
    case ":${PATH}:" in
        *":${d}:"*) ;;
        *) PATH="${d}:${PATH}" ;;
    esac
done
export PATH
