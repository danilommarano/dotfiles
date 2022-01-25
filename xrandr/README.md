# Configuração dos Monitores

Para criar o script de configuração utilizei um programa chamado Arandr, que fornece uma interface gráfica para criar configurações com o Xrandr. Para instalar em alguma distro debian, você precisa ter um gerenciador de pacotes chamado **Aptitude**:

```
sudo apt-get install aptitude
sudo aptitude install arandr
```

No tópico de instalação da documentação do [Arandr](https://christian.amsuess.com/tools/arandr/) é detalhado a forma de instalar em outras distribuições Linux.

Depois de instalado, inicie o Arandr, configure seus monitores e salve o script de configuração em qualquer lugar do seu computador. Para manter as alterações permanentes você precisa abrir/criar o arquivo `~/.xporfile` e adicionar a seguinte linha:

```
source /path/to/arandr/script
```

Assim, todas as vezes que você inicializar uma sessão Xorg, este script será executado e seus monitores configurados. :)
