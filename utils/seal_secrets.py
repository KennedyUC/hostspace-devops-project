import sys
import os
import subprocess

class SecretHandler():
    def __init__(self, secret_name: str, output_file: str) -> None:
        self.secret_name = secret_name
        self.output_file = output_file
        self.secret_file = "secret.yaml"

    def parse_key_value(self, input_str: str) -> tuple[str, str]:
        pair = input_str.split(':')
        key = pair[0].strip()
        value = pair[1].strip()
        return key, value

    def read_env_file(self, file_path: str) -> dict:
        key_value_pairs = {}
        with open(file_path, 'r') as file:
            for line in file:
                key, value = line.strip().split('=')
                key_value_pairs[key] = value
        return key_value_pairs

    def create_secret(self, key_value_pairs: dict):
        kubectl_command = [
            "kubectl",
            "create",
            "secret",
            "generic",
            self.secret_name,
            "--dry-run=client",
            *[f"--from-literal={key}={value}" for key, value in key_value_pairs.items()],
            "-o",
            "yaml"
        ]

        try:
            output = subprocess.check_output(kubectl_command, stderr=subprocess.STDOUT, text=True)
            return output
        except subprocess.CalledProcessError as e:
            print(f"Error creating Kubernetes secret: {e.output}")
            return None

    def seal_secret(self):
        kubeseal_command = [
            "kubeseal", 
            "--controller-name",
            "sealed-secret-sealed-secrets", 
            "--controller-namespace",
            "sealed-secret",
            "-f", 
            self.secret_file,
            "-w", 
            self.output_file
        ]

        try:
            output = subprocess.check_output(kubeseal_command, stderr=subprocess.STDOUT, text=True)
            return output
        except subprocess.CalledProcessError as e:
            print(f"Error creating kubeseal secret: {e.output}")
            return None

    def cleanup(self):
        os.remove(self.secret_file)

def main():
    secret_handler = SecretHandler(secret_name='db-secret', output_file='sealed-secret.yaml')
    if len(sys.argv) == 2 and os.path.isfile(sys.argv[1]):
            key_value_pairs = secret_handler.read_env_file(sys.argv[1])
    else:
        key_value_pairs = {}
        for arg in sys.argv[1:]:
            key, value = secret_handler.parse_key_value(arg)
            key_value_pairs[key] = value
    
    yaml_manifest = secret_handler.create_secret(key_value_pairs=key_value_pairs)

    if yaml_manifest:
        with open(secret_handler.secret_file, "w") as file_:
            file_.write(yaml_manifest)
        print(f"Secret YAML manifest saved to {secret_handler.secret_file}")
    else:
        print("Failed to generate Kubernetes secret YAML manifest.")

    secret_handler.seal_secret()
    secret_handler.cleanup()

if __name__ == '__main__':
    main()