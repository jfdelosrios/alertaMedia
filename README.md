# alertaMedia.

Asesor experto que envia mensaje cuando el precio esta cerca de la una cierta media movil. El mensaje puede llegar al MetaTrader de celular. 
El asesor experto lee un archivo sqlite guardado en .\AppData\Roaming\MetaQuotes\Terminal\Common\Files. El codigo solo puede ser compilado en MetaTrader 5.

![ ](https://github.com/jfdelosrios/alertaMediaMovil/blob/master/media/general.jpg)

## Acerca de la base de datos.

La base de datos se crea con dos archivos. 

* script csvToDB (anexo a este repositorio).
* mediaAlerta.csv (anexo ejemplo en este repositorio) que debe de guardarse en .\AppData\Roaming\MetaQuotes\Terminal\Common\Files
 
Con estos dos archivos se crea el archivo sqlite en .\AppData\Roaming\MetaQuotes\Terminal\Common\Files

## Acerca de mediaAlerta.csv

Contiene los siguientes campos:

* simbolo
* metodo: Tipo de media movil.
* Periodo: Periodo de la media movil.
* pixelesAdicionales
* puntosAdicionales: Cantidad de puntos adicionales entre la media movil y el precio Bid para que el mensaje sera disparado.

![ ](https://github.com/jfdelosrios/alertaMediaMovil/blob/master/media/parametrosEntrada.jpg)

## Archivos requeridos.

varios.mqh de https://github.com/jfdelosrios/varios_mqh.

## Pendientes

- [ ] Revisar el codigo de https://github.com/jfdelosrios/gatillos.




