# Dotfiles

## 1. Stow
Para organizar meus arquivos de configuração eu utilizo o GNU Stow, um 
gerenciador de links simbólicos. Ele faz com que arquivos localizados em 
diferentes diretórios sejam organizados num único só.

Eu aprendi a configurar e usar o Stow com 
[este](https://www.youtube.com/watch?v=CFzEuBGPPPg&t=1389s) vídeo (em inglês).
Além disso, a documentação dele pode ser encontrada 
[aqui](https://www.gnu.org/software/stow/manual/stow.html)


## 2. Configuração
Para utilizar as configurações deste repositório é preciso primeiro clona-lo.
Ele pode estar localizado em qualquer lugar e pode ser renomeado sem nenhum 
problema.

```
git clone https://github.com/danilommarano/dotfiles
```

Agora entre no diretório `dotfiles` e apague todas as pastas com configurações 
que você não deseja usar. É bem provavel que você não queira copiar a minha 
configuração do git e do teclado (_keyboard_), já que seu nome e email não são 
os mesmos e provavelmente não quer trocar o Caps-Lock pelo L-Ctrl.

```
cd dotfiles
rm -rf git keyboard
```

Antes de criar os links simbólicos necessários para espelhar todas as 
configurações execute o seguinte comando. 
```
stow -nvt ~ *
```
Ele usa três flags, a primeira é o `-n` que simula a execução do comando sem 
realizar alterações no seus sistema de arquivos, a próxima é o `-v` que 
explica "verbosamente" quais links simbólicos foram criados e por último o 
`-t`, que especifica o diretório _traget_ de onde ele vai partir para criar os 
links simbólicos, no caso o diretório `~` (home). Ou seja, para cada pasta 
dentro do diretório `dotfiles` ele vai criar um ou mais links simbólicos para 
replicar o sistema de arquivos a partir do diretório _home_.

Por fim, remova a flag `-n` e crie os links simbólicos usando o seguinte 
comando do Stow.
```
stow -vt ~ *
```

