# Java JAR Signing Demo

Demonstrates Java code signing with `jarsigner` -- signing, verification, and tamper detection.

## Prerequisites

- Java JDK 17+ (`javac`, `jar`, `keytool`, `jarsigner`)

Check:

```bash
java -version
```

## Run the demo

```bash
./sign-demo.sh
```

The script does the following:

1. Compiles `Hello.java` and packages it into `hello.jar`
2. Generates an RSA 2048 key pair in `keystore.jks` (self-signed certificate)
3. Signs `hello.jar` with `jarsigner`
4. Lists the contents of the signed JAR -- note `META-INF/MYKEY.SF` and `META-INF/MYKEY.RSA`
5. Verifies the signature with `jarsigner -verify -verbose`
6. Tamper detection: replaces `Hello.class` inside the JAR and attempts verification -- fails with `SecurityException: Invalid signature file digest`

## Step by step (manual)

```bash
# Compile and package
javac Hello.java
jar cfe hello.jar Hello Hello.class

# Generate key pair
keytool -genkeypair -alias mykey -keyalg RSA \
  -keysize 2048 -keystore keystore.jks \
  -storepass changeit \
  -dname "CN=CI/CD Security Course, O=KSE, L=Kyiv, C=UA"

# Sign
jarsigner -keystore keystore.jks -storepass changeit hello.jar mykey

# Verify
jarsigner -verify -verbose hello.jar
```

## What the signature looks like inside the JAR

```
META-INF/MANIFEST.MF   -- list of files + their SHA hashes
META-INF/MYKEY.SF      -- signed copy of the manifest
META-INF/MYKEY.RSA     -- the actual RSA signature + certificate
Hello.class            -- application code
```

Any modification to `Hello.class` after signing breaks the hash chain, and `jarsigner -verify` fails.

## Inspecting signature files inside the JAR

```bash
# List all files including signature metadata
jar tf hello.jar

# Read the manifest (contains SHA hashes of each file)
unzip -p hello.jar META-INF/MANIFEST.MF

# Read the signature file (signed copy of the manifest)
unzip -p hello.jar META-INF/MYKEY.SF
```
