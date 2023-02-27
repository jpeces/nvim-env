FROM alpine:latest
ARG USERNAME

RUN apk add --no-cache --update-cache \
        alpine-sdk \
        doas \
        xclip \
        xauth \
        ripgrep \
        neovim \
        neovim-doc \
        git; \
    adduser ${USERNAME} -G wheel; \
    echo 'permit :wheel as root' > /etc/doas.d/doas.conf; \
    echo 'permit nopass :wheel as root' >> /etc/doas.d/doas.conf

# Custom package
RUN apk add --no-cache --update-cache lazygit
RUN echo kk
RUN echo kk

WORKDIR /home/$USERNAME/.config/nvim
CMD ["/bin/sh"]

EXPOSE 22
