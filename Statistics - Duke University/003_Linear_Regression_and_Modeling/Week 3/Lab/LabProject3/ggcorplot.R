library(ggplot2)

#define a helper function (borrowed from the "ez" package)
ezLev=function(x,new_order){
	for(i in rev(new_order)){
		x=relevel(x,ref=i)
	}
	return(x)
}

ggcorplot = function(data,var_text_size,cor_text_limits){
	# normalize data
	for(i in 1:length(data)){
		data[,i]=(data[,i]-mean(data[,i]))/sd(data[,i])
	}
	# obtain new data frame
	z=data.frame()
	i = 1
	j = i
	while(i<=length(data)){
		if(j>length(data)){
			i=i+1
			j=i
		}else{
			x = data[,i]
			y = data[,j]
			temp=as.data.frame(cbind(x,y))
			temp=cbind(temp,names(data)[i],names(data)[j])
			z=rbind(z,temp)
			j=j+1
		}
	}
	names(z)=c('x','y','x_lab','y_lab')
	z$x_lab = ezLev(factor(z$x_lab),names(data))
	z$y_lab = ezLev(factor(z$y_lab),names(data))
	z=z[z$x_lab!=z$y_lab,]
	#obtain correlation values
	z_cor = data.frame()
	i = 1
	j = i
	while(i<=length(data)){
		if(j>length(data)){
			i=i+1
			j=i
		}else{
			x = data[,i]
			y = data[,j]
			x_mid = min(x)+diff(range(x))/2
			y_mid = min(y)+diff(range(y))/2
			this_cor = cor(x,y)
			this_cor.test = cor.test(x,y)
			this_col = ifelse(this_cor.test$p.value<.05,'<.05','>.05')
			this_size = (this_cor)^2
			cor_text = ifelse(
				this_cor>0
				,substr(format(c(this_cor,.123456789),digits=2)[1],2,4)
				,paste('-',substr(format(c(this_cor,.123456789),digits=2)[1],3,5),sep='')
			)
			b=as.data.frame(cor_text)
			b=cbind(b,x_mid,y_mid,this_col,this_size,names(data)[j],names(data)[i])
			z_cor=rbind(z_cor,b)
			j=j+1
		}
	}
	names(z_cor)=c('cor','x_mid','y_mid','p','rsq','x_lab','y_lab')
	z_cor$x_lab = ezLev(factor(z_cor$x_lab),names(data))
	z_cor$y_lab = ezLev(factor(z_cor$y_lab),names(data))
	diag = z_cor[z_cor$x_lab==z_cor$y_lab,]
	z_cor=z_cor[z_cor$x_lab!=z_cor$y_lab,]
	#start creating layers
	points_layer = layer(
		geom = 'point'
		, data = z
		, mapping = aes(
			x = x
			, y = y
		)
	)
	lm_line_layer = layer(
		geom = 'line'
		, geom_params = list(colour = 'red')
		, stat = 'smooth'
		, stat_params = list(method = 'lm')
		, data = z
		, mapping = aes(
			x = x
			, y = y
		)
	)
	lm_ribbon_layer = layer(
		geom = 'ribbon'
		, geom_params = list(fill = 'green', alpha = .5)
		, stat = 'smooth'
		, stat_params = list(method = 'lm')
		, data = z
		, mapping = aes(
			x = x
			, y = y
		)
	)
	cor_text = layer(
		geom = 'text'
		, data = z_cor
		, mapping = aes(
			x=y_mid
			, y=x_mid
			, label=cor
			, size = rsq
			, colour = p
		)
	)
	var_text = layer(
		geom = 'text'
		, geom_params = list(size=var_text_size)
		, data = diag
		, mapping = aes(
			x=y_mid
			, y=x_mid
			, label=x_lab
		)
	)
	f = facet_grid(y_lab~x_lab,scales='free')
	o = opts(
		panel.grid.minor = theme_blank()
		,panel.grid.major = theme_blank()
		,axis.ticks = theme_blank()
		,axis.text.y = theme_blank()
		,axis.text.x = theme_blank()
		,axis.title.y = theme_blank()
		,axis.title.x = theme_blank()
		,legend.position='none'
	)
	size_scale = scale_size(limits = c(0,1),to=cor_text_limits)
	return(
		ggplot()+
		points_layer+
		lm_ribbon_layer+
		lm_line_layer+
		var_text+
		cor_text+
		f+
		o+
		size_scale
	)
}

#set up some fake data
library(MASS)
N=100

#first pair of variables
variance1=1
variance2=2
mean1=10
mean2=20
rho = .8
Sigma=matrix(c(variance1,sqrt(variance1*variance2)*rho,sqrt(variance1*variance2)*rho,variance2),2,2)
pair1=mvrnorm(N,c(mean1,mean2),Sigma,empirical=T)

#second pair of variables
variance1=10
variance2=20
mean1=100
mean2=200
rho = -.4
Sigma=matrix(c(variance1,sqrt(variance1*variance2)*rho,sqrt(variance1*variance2)*rho,variance2),2,2)
pair2=mvrnorm(N,c(mean1,mean2),Sigma,empirical=T)

my_data=data.frame(cbind(pair1,pair2))

ggcorplot(
	data = my_data
	, var_text_size = 30
	, cor_text_limits = c(2,30)
)
