#!/bin/sh

##
## VARIAVEIS
##
TCP_PUB_PORTS="80,21,443"
UDP_PUB_PORTS="53"
TCP_PRIV_PORTS="8110"
UDP_PRIV_PORTS="53"
##
##
##
IPT="iptables"
IPS="ipset"
echo " LIMPANDO REGRAS E LISTAS"
$IPT -F
$IPS destroy

#
# ALTERA POLITICA PADRAO
#
echo " MUDANDO POLITICA PADRAO PARA DROP"
$IPT -P INPUT DROP
$IPT -A INPUT -i lo0 -j ACCEPT 
#
# LIBERA INPUT GERENCIA
#
echo " CRIANDO REGRAS INPUT - GERENCIA"
$IPS create LISTA-GERENCIA iphash
while read IP; do
    $IPS add LISTA-GERENCIA $IP
done < /srv/scripts/firewall/LISTA-GERENCIA.txt
$IPT -A INPUT -m set --match-set LISTA-GERENCIA src,dst -j ACCEPT -m comment --comment "PERMITE ACESSO IRRESTRITO AOS IPS DE GERENCIA"
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT -m comment --comment "PERMITE PACOTES ESTABLISHED/RELATED"

#
# BLOQUEIA ACESSO SERVICOS GERENCIA
#
#echo " CRIANDO REGRAS DE BLOQUEIO A SERVICOS DE GERENCIA"
#$IPT -A INPUT -p tcp -m multiport --dport ${TCP_PRIV_PORTS} -j DROP -m comment --comment "BLOQUEIA ACESSO A SERVICOS DE GERENCIA/TCP"
#$IPT -A INPUT -p udp -m multiport --dport ${UDP_PRIV_PORTS} -j DROP -m comment --comment "BLOQUEIA ACESSO A SERVICOS DE GERENCIA/UDP"

#
# LIBERA ACESSO A SERVICOS PUBLICOS TCP/UDP
#
$IPT -A INPUT -p tcp -m multiport --dport ${TCP_PUB_PORTS} -m state --state NEW -j ACCEPT -m comment --comment "ACESSO LIBERADO PARA SERVICOS PUBLICOS/TCP"
$IPT -A INPUT -p udp -m multiport --dport ${UDP_PUB_PORTS} -m state --state NEW -j ACCEPT -m comment --comment "ACESSO LIBERADO PARA SERVICOS PUBLICOS/UDP"
