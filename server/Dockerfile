############################
# STEP 1 build executable binary
############################
FROM golang:alpine AS builder
# Install git.
# Git is required for fetching the dependencies.
RUN apk update && apk add --no-cache git

# Create the user and group files that will be used in the running container to
# run the process as an unprivileged user.
RUN mkdir /user && \
    echo 'nobody:x:65534:65534:nobody:/:' > /user/passwd && \
    echo 'nobody:x:65534:' > /user/group


#compile linux only and have module support so we don't have to rely on git pull breaking builds
ENV GOOS=linux
ENV GO111MODULE on

WORKDIR /build

# Fetch dependencies first; they are less susceptible to change on every build
# and will therefore be cached for speeding up the next build
COPY ./go.mod ./
RUN go mod download

# Import the rest of the code (TODO - not sure if this is recursive, so if you add a directory, check)
COPY ./ ./

# Build the executable to `/app`. Mark the build as statically linked.
RUN CGO_ENABLED=0 go build \
    -installsuffix 'static' \
    -o /app .

############################
# STEP 2: build an even smaller image!
#         step 1 build phase requires an entire linux subsystem, which is 100's of megabytes
#         we source from that to pull just the binary (in the future, maybe static files too?)
#         and then only use that (scratch is essentially an empty buffer)
############################
FROM scratch
# Import the user and group files from the first stage. This allows unpriveledged user to run, since
# I dislike root.
COPY --from=builder /user/group /user/passwd /etc/

# Import the Certificate-Authority certificates for enabling HTTPS. TODO - implement https :)
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Import the compiled executable from the first stage.
COPY --from=builder /app /app

# Declare the port on which the webserver will be exposed.
# As we're going to run the executable as an unprivileged user, we can't bind
# to ports below 1024.
EXPOSE 8080

# Perform any further action as an unprivileged user.
USER nobody:nobody

# Run the compiled binary.
ENTRYPOINT ["/app"]