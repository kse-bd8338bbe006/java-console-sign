#!/usr/bin/env bash
set -euo pipefail

echo "=== Java JAR Signing Demo ==="
echo ""

# 1. Compile
echo "1. Compiling Hello.java..."
javac Hello.java
echo "   Done."

# 2. Package into JAR
echo "2. Packaging hello.jar..."
jar cfe hello.jar Hello Hello.class
echo "   Done. Running: $(java -jar hello.jar)"

# 3. Generate keystore
echo "3. Generating RSA 2048 key pair in keystore.jks..."
keytool -genkeypair -alias mykey -keyalg RSA \
  -keysize 2048 -keystore keystore.jks \
  -storepass changeit \
  -dname "CN=CI/CD Security Course, O=KSE, L=Kyiv, C=UA" \
  -validity 365 2>&1
echo "   Done."

# 4. Sign the JAR
echo "4. Signing hello.jar with jarsigner..."
jarsigner -keystore keystore.jks -storepass changeit hello.jar mykey 2>&1
echo ""

# 5. Show signature files inside JAR
echo "5. Files inside signed JAR:"
jar tf hello.jar
echo ""

# 6. Verify signature
echo "6. Verifying signature..."
jarsigner -verify -verbose hello.jar 2>&1
echo ""

# 7. Tamper detection demo
echo "7. Tamper detection demo..."
echo "   Extracting JAR, replacing Hello.class with tampered version..."
mkdir -p tampered
cd tampered
jar xf ../hello.jar
cat > Hello.java << 'JAVA'
public class Hello {
    public static void main(String[] args) {
        System.out.println("TAMPERED!");
    }
}
JAVA
javac Hello.java
jar cf ../hello-tampered.jar -C . .
cd ..
rm -rf tampered

echo "   Verifying tampered JAR..."
if jarsigner -verify hello-tampered.jar 2>&1; then
  echo "   ERROR: tampered JAR passed verification (unexpected)"
else
  echo "   Tamper detected! Signature verification failed as expected."
fi

echo ""
echo "=== Demo complete ==="
