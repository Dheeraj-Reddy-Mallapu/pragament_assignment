import os
import subprocess

keytool_path = "C:\\Program Files\\Java\\jre-1.8\\bin\\keytool.exe"
keystore_password = "sussyBaka"
key_password = "sussyBaka"
key_alias = "baka"
keystore_file = f"./key.jks"

# Generate keystore file
subprocess.run([keytool_path])
subprocess.run([keytool_path, "-genkey", "-v", "-keystore", keystore_file, "-keyalg", "RSA", "-keysize", "2048", "-validity", "10000", "-alias", key_alias, "-storepass", keystore_password, "-keypass", key_password])

# Create key.properties file
key_properties_content = f"""storePassword={keystore_password}
keyPassword={key_password}
keyAlias={key_alias}
storeFile={keystore_file}"""

with open("key.properties", "w") as f:
    f.write(key_properties_content)
