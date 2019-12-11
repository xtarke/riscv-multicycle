# VGA

O controlador VGA está padronizado para a resolução 800x600 a 60Hz.
Para alterar a resolução, instanciar o controlador conforme 'timings' dos [Padrões VGA](http://tinyvga.com/vga-timing).
O controlador VGA necessita de uma RAM Dual Channel e de um PLL de 40MHz, conforme esquemático:
![RTL](https://drive.google.com/file/d/1flgcUsC5myYFzawOMX-cEWR_tmpqch94/view?usp=sharing)

## Integração com o CORE
Para o CORE não gravar duplicado (na RAM de dados e na RAM da VGA), é necessário incluir o código seguinte e ligar os respectivos sinais as memórias:
```vhdl
process(dcsel, d_we)
begin
	if dcsel = "11" then
		wren_vga <= d_we; -- write to vga
		wren_dm  <= '0';
	else
		wren_vga <= '0';
		wren_dm  <= d_we; -- write do data memory
	end if;
end process;
```

## To Do
Se a memória não suportar dados de um frame inteiro, o controlador irá repetir os dados da memória. Porém, com uma memória de 8kb é possível fazer uma imagem de 90x90 pixels. Os arquivos 'reescale' intentam fazer isso, incrementando o endereço da memória somente quando o pixel está dentro da linha e da coluna, e colocando preto quando estiver fora. 

### Links Úteis
[Controlador VGA VHDL](https://www.digikey.com/eewiki/pages/viewpage.action?pageId=15925278)


