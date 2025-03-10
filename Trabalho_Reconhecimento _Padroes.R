#grupo - Amanda Pita, Alessandra Santos e Melissa Ribeiro
#codigo completo

library("pvclust")
library("cluster")
library("ggplot2")
library("dendextend")
library("factoextra")
library("dplyr")
library("tidyverse")
library("gridExtra")

#inserir dados
dadosbase = read.delim("Mvalues_ACTped.txt", header = TRUE)

#virar matriz
dadost = t(dadosbase)

#vetores
algoritmos = c("Hartigan-Wong", "Forgy", "MacQueen")
distancias = c("correlation", "uncentered", "euclidean", "manhattan")
metricas = c("euclidean", "manhattan")
metodos = c("average", "single", "complete", "weighted", "ward")
pv_metodos = c("average", "ward.D", "ward.D2", "single", "complete", "mcquitty", "median", "centroid")
stands = c(TRUE , FALSE)

#matriz para salvar os grupos
matriz <- matrix(0, 57, 65)
p=1

# agnes
for (i in 1:2){
    for (j in 1:5){
        for (l in 1:2) {
            agn = agnes(dadost, metric = metricas[i], stand = stands[l], method = metodos[j])
            grafico = plot(agn, hang = -1)
            rect.hclust(agn, k = 4, border = "red") 
            grupos = c(cutree(agn, k = 4))
	        matriz[,p] <- grupos
	        p = p+1
        }
    }
}

p=p+1 # para “pular” uma linha na matriz

# diana
for (i in 1:2){
    for (j in 1:2){
        dia = diana(dadost, metric = metricas[i], stand = stands[j])
        grafico = plot(dia, hang = -1)
        rect.hclust(dia, k = 4, border = "red")
        grupos = c(cutree(dia, k = 4))
        matriz[,p] <- grupos
        p = p+1
    }
}

p=p+1 # para “pular” uma linha na matriz

# pam
for (i in 1:2) {
    dados_pam = pam(dadost, k = 4, metric = metricas[i])
    plot(fviz_silhouette(dados_pam, label = TRUE))
    plot(fviz_cluster(dados_pam))
    grupos <- (dados_pam$clustering)
    matriz[,p] <- grupos
    p = p+1
}

p=p+1 # para “pular” uma linha na matriz

#kmeans
for (i in 1:3) {
    kme = kmeans(dadost, centers = 4, algorithm = algoritmos[i])
    plot (fviz_cluster(kme, data=dadost, main = algoritmos[i]))
    grupos <- (kme$cluster)
    matriz[,p] <- grupos
    p=p+1
    # plots to compare
    k1 <- kmeans(dadost, centers = 1, algorithm = algoritmos[i])
    k2 <- kmeans(dadost, centers = 2, algorithm = algoritmos[i])
    k3 <- kmeans(dadost, centers = 3, algorithm = algoritmos[i])
  	k4 <- kmeans(dadost, centers = 4, algorithm = algoritmos[i])
  	p1 <- fviz_cluster(k1, geom = "point", data = dadost) + ggtitle("k = 1")
  	p2 <- fviz_cluster(k2, geom = "point",  data = dadost) + ggtitle("k = 2")
  	p3 <- fviz_cluster(k3, geom = "point",  data = dadost) + ggtitle("k = 3")
  	p4 <- fviz_cluster(k4, geom = "point",  data = dadost) + ggtitle("k = 4")
  	grid.arrange(p1, p2, p3, p4, nrow = 2)
}

p=p+1 # para “pular” uma linha na matriz

#pvclust
for(i in 1:4){
    for(j in 1:8){
    	pvc <- pvclust((as.data.frame(dadosbase)), method.dist = distancias[i], method.hclust = pv_metodos[j], nboot = 5, r=1)
    	grafico = plot(pvc, print.pv = FALSE, hang = -1)
    	dend <- as.dendrogram(pvc)
		dend %>% set(k=4) %>% plot()
		if((i==1 && j!=7) || (i==2 && j!=7) || (i>2)){
			dend %>%rect.dendrogram(k=4, border = "red")
    	}
    	grupos = c(cutree(pvc$hclust, k = 4))
    	matriz[,p] <- grupos
		p=p+1
    }
}

# matriz de distancia
distancia <- get_dist(dadost)
fviz_dist(distancia, gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))
 
tabela_resultados = t(matriz)
