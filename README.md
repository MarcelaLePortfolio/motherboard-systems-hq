This project is pinned to specific tool versions to ensure stability:

- Node.js: v20.19.4
- pnpm: v10.16.1

We use Volta (https://volta.sh) to manage these versions automatically.

1. Install Volta (if not already installed):
   curl https://get.volta.sh | bash
   exec zsh

2. Pin Node.js:
   volta install node@20.19.4
   volta pin node@20.19.4

3. Install pnpm:
   volta install pnpm@10.16.1

Volta will ensure the correct versions are always used inside this project.
If you try to run with the wrong version, the preinstall script will block it:

❌ pnpm 10.16.1 required (found X.X.X)
❌ Node v20.19.4 required (found vX.X.X)

With this setup, you can clone the repo on any machine, install Volta, and everything just works.
