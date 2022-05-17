#!/usr/bin/perl -w

#========================================================================================
# Auteur : Axel Goret
# Date : 16/05/2022
# Version : 1.0
# Objectif : plugin Centreon de vérification du processus le plus demandeur en ressources
#========================================================================================

use strict;                 # Rends la déclaration de variables obligatoire
use warnings;               # Affiche les messages d'avertissements
use Monitoring::Plugin;     # Classe plugin de monitoring

# déclaration du nouveau plugin
my $newPlugin = Monitoring::Plugin->new(
        shortname => 'top cpu process',
        usage => 'Utilisation : %s -c|critical <threshold> -w|warning <threshold>',
        version => '1.0',
        blurb => "Ce plugin affiche le processus qui utilise le plus le processeur".
                 "Les parametres sont obligatoires, ils sont a exprimer en pourcentage@"
);



# definition du paramètre critical (--critical ou -c)
$newPlugin->add_arg(
        spec => 'critical|c=f',
        help => 'Pourcentage utilisation critique',    # Information complémentaires pour cet argument
        required => 1,                                 # Rends l'argument obligatoire
);

# définition du paramètre warning (--warning ou -w)
$newPlugin->add_arg(
        spec => 'warning|w=f',
        help => 'Pourcentage utilisation warning',     # Information complémentaire pour cet argument
        required => 1,                                 # Rends l'argument obligatoire
);


# Récupérations des arguments dans la ligne de commande
$newPlugin->getopts;


# Logique du plugin - corps du programme
# Déclaration des variables - options de la commande ps
my $cpu;
my $pid;
my $user;
my $commande;
my $codeRetour;

# corps du plugin
open(FILE, "ps -eo pcpu,pid,user,cmd | tail -n +2 | sort -k 1 -n -r | head -1 |");
while(<FILE>){
	($cpu,$pid,$user,$commande) = split;
        # Ajout de données pour la génération d'un graphique sous Centreon
        $newPlugin->add_perfdata(
                label => "greedy_process",
                value => $cpu,
                uom => "%",
                warning => $newPlugin->opts->warning,           # Affiche le seuil d'avertissement sur Centreon
                critical => $newPlugin->opts->critical          # Affiche le seuil critique sur Centreon
        );

	# Récupération du code de retour en fonction du seuil d'utilisation du cpu
        $codeRetour = $newPlugin->check_threshold(
                check => $cpu,          #Vérifie l'utilisation du cpu, stocké dans la variable $cpu
                warning => $newPlugin->opts->warning,
                critical => $newPlugin->opts->critical
        );

        # Affichage en fonction du code de retour (OK, WARNING ou CRITICAL)
        $newPlugin->plugin_exit( $codeRetour, "Processus Critique : $commande utilise le cpu a $cpu%" ) if $codeRetour == CRITICAL;
        $newPlugin->plugin_exit( $codeRetour, "Processus Avertissement : $commande utilise le cpu a $cpu%" ) if $codeRetour == WARNING;
        $newPlugin->plugin_exit( $codeRetour, "Tous les processus OK" ) if $codeRetour == OK;
}

__END__</threshold></threshold>
