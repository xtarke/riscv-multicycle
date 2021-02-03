# Count Debounce

Quando um botão é pressionado, ele gera oscilações de alta frequência. Se essas altas frequências não forem filtradas, podem causar interpretações erradas, pois essas oscilações podem ser confundidas como se o botão tivesse sido pressionado mais vezes. 

Para que isso não ocorra utiliza-se filtros de entrada, que podem ser analógicos ou digitais. A técnica de debounce é um filtro digital que remove os repiques de alta frequência causado pelo pressionamento de chaves mecânicas. Utilizou-se nessa implementação o debounce por contagem. 

O debounce por contagem considera o instante em que uma chave é acionada para iniciar um contador. Quando esse contador termina a contagem, a lógica do botão é acionada a partir da saída do debounce.  

Esse método permite a implementação de um gpio mais sofisticado, já que todas as entradas passam por um filtro implementado de maneira digital. 


![debouncer_image](https://user-images.githubusercontent.com/39311424/95769575-7acbd480-0c8e-11eb-9a47-d7d316e88712.png)


# Simulação 
Para essa implementação foi utilizado um período de contagem de 500 us de maneira que qualquer ruído com período menor que esse seja filtrado. 

![print_periodo](https://user-images.githubusercontent.com/39311424/95769526-6982c800-0c8e-11eb-93b5-fd55ee2f7459.png)


# Software utilizado
O software utilizado para o debounce é o mesmo do exemplo do blink.c. 
