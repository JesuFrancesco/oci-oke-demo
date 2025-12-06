# backend

1. crear imagen docker

```sh
docker build -t oci-oke-demo:latest .
```

2. obtener namespace

```sh
oci os ns get # => namespace
```

3. pushaer a oci ocr

```sh
docker tag -t oci-oke-demo:latest iad.ocir.io/<namespace>/oci-oke-demo:latest
```
