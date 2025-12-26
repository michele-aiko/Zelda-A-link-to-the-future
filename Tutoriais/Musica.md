# Como adicionar músicas no seu jogo

## 1 - Obtenha o arquivo midi da música desejada
Você pode procurar no seu buscador  'nome da música desejada + midi' e provavelmente você vai achar. Para o nosso jogo foi utilizada a plataforma [Ninsheet](https://www.ninsheetmusic.org/), que possui uma vasta coleção de músicas de jogos da Nintendo.

### Convertendo músicas/efeitos sonoros do youtube para midi
Caso a música/efeito sonoro que você deseja não tenha um arquivo midi pronto na internet, converta usando um conversor Youtube/MP3 para Midi como o [La Touche Musicale](https://latouchemusicale.com/en/tools/youtube-to-midi-converter/).

## 2 - Utilize o Midi converter 
1- Baixe os arquivos do [Repositório do Midi Converter](https://github.com/fer-amdias/RISCV-midiconverter/tree/main) feito pelo [Fernando Dias](https://github.com/fer-amdias).

2- Instale python e o Mido caso você não tenha na sua máquina. Para instalar o Mido rode o comando
```bash
pip install mido
```


3- Coloque o arquivo do <code>midiconverter.py</code> e sua <code>musica.mid</code> na mesma pasta e rode o comando
```bash 
python midiconverter.py musica.mid
```

Agora você tem o arquivo musica.data

## Implementando a música no jogo
Para implementar a música, iremos usar o [audioplayer criado pelo Fernando](https://github.com/fer-amdias/RISCV-midiconverter/blob/main/gameloop_demo/portugues/audioplayer_PT.s)

Importe o audioplayer no seu arquivo principal do jogo e configure dentro do gameloop qual música você deseja tocar.

Confira como implementar nesse [exemplo de gameloop](https://github.com/fer-amdias/RISCV-midiconverter/blob/main/gameloop_demo/portugues/gameloop_demo_PT.s)


