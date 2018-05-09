FROM GRUB_TAG as grub

FROM linuxkit/alpine:77287352db68b442534c0005edd6ff750c8189f3
RUN apk add --no-cache \
  mtools \
  dosfstools \
  libarchive-tools \
  sgdisk \
  coreutils

WORKDIR /
COPY make-flash .
# NOTE: the order matters here since we have a custome grub.cfg
# that needs to overwrite the one coming from default grub
COPY --from=grub / /efifs/
COPY /efi-files /efifs

ENTRYPOINT [ "/make-flash" ]
