# go-fast-install

Script de instalación rápida para Go (Golang) en Linux. Soporte automático para amd64 y arm64.

El fin de este script es proporcionar una guia rapida de configuración para iniciar el desarrollo en Go.

## Guia de uso

1. Clonar repositorio y moverse a `cd go-fast-install`

2. Asignar permisos de ejecusion del script `install_go.sh`

    ``` bash
    chmod +x install_go.sh
    ```

3. Ejecutar script, es importante pasar como argumento la version de Golang que desea instalar en su sistema Linux, de lo contrario este le advertira y finalizara la ejecución del script, ejemplo:

    ``` bash
    ./install_go.sh 1.25.5
   ```

*Nota: para más detalles sobre las versiones puedes consultar este [link que te lleva a la página oficial](https://go.dev/dl/)*

---

Desarrollado con IA, de un dev para devs ❤️ by [Edy Rojas](https://github.com/edyrrg)
