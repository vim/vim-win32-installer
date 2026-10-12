# vi:set ts=8 sts=4 sw=4 et fdm=marker:
#
# french.nsi: French language strings for gvim NSIS installer.
#
# Locale ID    : 1036
# Locale Name  : fr
# fileencoding : UTF-8
# Author       : Sylvain Cresto

!insertmacro MUI_LANGUAGE "French"


# Overwrite the default translation.
# These strings should be always English.  Otherwise dosinst.c fails.
LangString ^SetupCaption     ${LANG_FRENCH} \
        "$(^Name) Setup"
LangString ^UninstallCaption ${LANG_FRENCH} \
        "$(^Name) Uninstall"

##############################################################################
# Translated license file for the license page                            {{{1
##############################################################################

LicenseLangString page_lic_file 0 "${SRC}\lang\LICENSE.nsis.txt"
#LicenseLangString page_lic_file ${LANG_FRENCH} "${SRC}\lang\LICENSE.fr.nsis.txt"

##############################################################################
# Translated README.txt file, which is opened after installation          {{{1
##############################################################################

LangString vim_readme_file 0 "README.txt"
#LangString vim_readme_file ${LANG_FRENCH} "README.fr.txt"

##############################################################################
# MUI Configuration Strings                                               {{{1
##############################################################################

#LangString str_dest_folder          ${LANG_FRENCH} \
#    "Dossier de destination (doit se terminer par $\"vim$\")"

LangString str_show_readme          ${LANG_FRENCH} \
    "Afficher le README à la fin de l'installation"

# Install types:
LangString str_type_typical         ${LANG_FRENCH} \
    "Standard"

LangString str_type_minimal         ${LANG_FRENCH} \
    "Minimale"

LangString str_type_full            ${LANG_FRENCH} \
    "Complète"


##############################################################################
# Section Titles & Description                                            {{{1
##############################################################################

LangString str_section_old_ver      ${LANG_FRENCH} \
    "Désinstaller les versions existantes"
LangString str_desc_old_ver         ${LANG_FRENCH} \
    "Désinstalle les versions de Vim déjà présentes sur votre système."

LangString str_section_exe          ${LANG_FRENCH} \
    "Interface graphique de Vim"
LangString str_desc_exe             ${LANG_FRENCH} \
    "Interface graphique de Vim et fichiers d'exécution.  \
     Ce composant est obligatoire."

LangString str_section_console      ${LANG_FRENCH} \
    "Programme Vim en mode console"
LangString str_desc_console         ${LANG_FRENCH} \
    "Version console de Vim (vim.exe)."

LangString str_group_cmdline        ${LANG_FRENCH} \
    "Prise en charge de la lige de commande"
LangString str_desc_cmdline         ${LANG_FRENCH} \
    "Facilite l'utilisation de Vim depuis la ligne de commande."

#LangString str_section_batch        ${LANG_FRENCH} \
#    "Créer des fichiers .bat"
#LangString str_desc_batch           ${LANG_FRENCH} \
#    "Crée des fichiers .bat pour les variantes de Vim dans le répertoire \
#     Windows, pour la ligne de commande."

LangString str_section_launcher     ${LANG_FRENCH} \
    "Lanceurs de Vim"
LangString str_desc_launcher        ${LANG_FRENCH} \
    "Installe de petits programmes pour les variantes de Vim dans le \
     répertoire Windows, pour la ligne de commande."

LangString str_section_addpath      ${LANG_FRENCH} \
    "Ajouter au PATH"
LangString str_desc_addpath         ${LANG_FRENCH} \
    "Ajoute le répertoire de Vim à la variable d'environnement PATH."

LangString str_group_icons          ${LANG_FRENCH} \
    "Créer des raccourcis vers Vim"
LangString str_desc_icons           ${LANG_FRENCH} \
    "Créer des raccourcis pour lancer Vim facilement."

LangString str_section_desktop      ${LANG_FRENCH} \
    "Sur le Bureau"
LangString str_desc_desktop         ${LANG_FRENCH} \
    "Crée des icônes pour les exécutables de gVim sur le Bureau."

LangString str_section_start_menu   ${LANG_FRENCH} \
    "Dans le menu Démarrer"
LangString str_desc_start_menu      ${LANG_FRENCH} \
    "Ajoute Vim dans le dossier Programmes du menu Démarrer."

#LangString str_section_quick_launch ${LANG_FRENCH} \
#    "Dans la barre de lancement rapide"
#LangString str_desc_quick_launch    ${LANG_FRENCH} \
#    "Ajoute un raccourci vers Vim dans la barre de lancement rapide."

LangString str_section_edit_with    ${LANG_FRENCH} \
    "Ajouter Vim au menu contextuel"
LangString str_desc_edit_with       ${LANG_FRENCH} \
    "Ajoute Vim à la liste $\"Ouvrir avec...$\" du menu contextuel."

#LangString str_section_edit_with32  ${LANG_FRENCH} \
#    "Version 32 bits"
#LangString str_desc_edit_with32     ${LANG_FRENCH} \
#    "Ajoute Vim à la liste $\"Ouvrir avec...$\" du menu contextuel \
#     pour les applications 32 bits."

#LangString str_section_edit_with64  ${LANG_FRENCH} \
#    "Version 64 bits"
#LangString str_desc_edit_with64     ${LANG_FRENCH} \
#    "Ajoute Vim à la liste $\"Ouvrir avec...$\" du menu contextuel \
#     pour les applications 64 bits."

LangString str_section_vim_rc       ${LANG_FRENCH} \
    "Créer la configuration par défaut"
LangString str_desc_vim_rc          ${LANG_FRENCH} \
    "Crée le fichier de configuration par défaut (_vimrc) s'il \
     n'existe pas déjà."

LangString str_group_plugin         ${LANG_FRENCH} \
    "Créer les répertoires de plugins"
LangString str_desc_plugin          ${LANG_FRENCH} \
    "Crée les répertoires de plugins. Ils permettent d'étendre Vim \
     en y déposant simplement un fichier."

LangString str_section_plugin_home  ${LANG_FRENCH} \
    "Personnels"
LangString str_desc_plugin_home     ${LANG_FRENCH} \
    "Crée les répertoires de plugins dans le répertoire HOME."

LangString str_section_plugin_vim   ${LANG_FRENCH} \
    "Partagés"
LangString str_desc_plugin_vim      ${LANG_FRENCH} \
    "Crée les répertoires de plugins dans le répertoire d'installation \
     de Vim, pour tous les utilisateurs."

LangString str_section_nls          ${LANG_FRENCH} \
    "Prise en charge des langues"
LangString str_desc_nls             ${LANG_FRENCH} \
    "Installe les fichiers de prise en charge des langues."

LangString str_unsection_register   ${LANG_FRENCH} \
    "Désinstaller Vim"
LangString str_desc_unregister      ${LANG_FRENCH} \
    "Désinstaller Vim du système."

LangString str_unsection_exe        ${LANG_FRENCH} \
    "Supprimer les exécutables et fichiers d'exécution de Vim"
LangString str_desc_rm_exe          ${LANG_FRENCH} \
    "Supprime tous les exécutables et fichiers d'exécution de Vim."

LangString str_ungroup_plugin       ${LANG_FRENCH} \
    "Supprimer les répertoires de plugins"
LangString str_desc_rm_plugin       ${LANG_FRENCH} \
    "Supprime les répertoires de plugins s'ils sont vides."

LangString str_unsection_plugin_home ${LANG_FRENCH} \
    "Personnels"
LangString str_desc_rm_plugin_home  ${LANG_FRENCH} \
    "Supprime les répertoires de plugins du répertoire HOME."

LangString str_unsection_plugin_vim ${LANG_FRENCH} \
    "Partagés"
LangString str_desc_rm_plugin_vim   ${LANG_FRENCH} \
    "Supprime les répertoires de plugins du répertoire d'installation \
     de Vim."

LangString str_unsection_rootdir    ${LANG_FRENCH} \
    "Supprimer le répertoire d'installation de Vim"
LangString str_desc_rm_rootdir      ${LANG_FRENCH} \
    "Supprime le répertoire d'installation de Vim. Il contient les fichiers de \
     configuration de Vim !"


##############################################################################
# Messages                                                                {{{1
##############################################################################

#LangString str_msg_too_many_ver  ${LANG_FRENCH} \
#    "$vim_old_ver_count versions de Vim trouvées sur votre système.$\r$\n\
#     Ce programme d'installation ne peut en gérer que \
#     ${VIM_MAX_OLD_VER} au maximum.$\r$\n\
#     Veuillez en supprimer quelques-unes et recommencer."

#LangString str_msg_invalid_root  ${LANG_FRENCH} \
#    "Chemin d'installation invalide : $vim_install_root !$\r$\n\
#     Il doit se terminer par $\"vim$\"."

#LangString str_msg_bin_mismatch  ${LANG_FRENCH} \
#    "Chemin des binaires incohérent !$\r$\n$\r$\n\
#     Le chemin attendu est $\"$vim_bin_path$\",$\r$\n\
#     mais le système indique $\"$INSTDIR$\"."

#LangString str_msg_vim_running   ${LANG_FRENCH} \
#    "Vim est toujours en cours d'exécution sur votre système.$\r$\n\
#     Veuillez fermer toutes les instances de Vim avant de continuer."

#LangString str_msg_register_ole  ${LANG_FRENCH} \
#    "Tentative d'enregistrement de Vim auprès d'OLE. \
#     Aucun message n'indiquera si l'opération a réussi."

#LangString str_msg_unreg_ole     ${LANG_FRENCH} \
#    "Tentative de désenregistrement de Vim auprès d'OLE. \
#     Aucun message n'indiquera si l'opération a réussi."

#LangString str_msg_rm_start      ${LANG_FRENCH} \
#    "Désinstallation de la version suivante :"

#LangString str_msg_rm_fail       ${LANG_FRENCH} \
#    "Échec de la désinstallation de la version suivante :"

#LangString str_msg_no_rm_key     ${LANG_FRENCH} \
#    "Clé de registre du programme de désinstallation introuvable."

#LangString str_msg_no_rm_reg     ${LANG_FRENCH} \
#    "Programme de désinstallation introuvable dans le registre."

#LangString str_msg_no_rm_exe     ${LANG_FRENCH} \
#    "Impossible d'accéder au programme de désinstallation."

#LangString str_msg_rm_copy_fail  ${LANG_FRENCH} \
#    "Impossible de copier le programme de désinstallation dans le \
#     répertoire temporaire."

#LangString str_msg_rm_run_fail   ${LANG_FRENCH} \
#    "Impossible de lancer le programme de désinstallation."

#LangString str_msg_abort_install ${LANG_FRENCH} \
#    "L'installation va être interrompue."

LangString str_msg_install_fail  ${LANG_FRENCH} \
    "L'installation a échoué."

LangString str_msg_rm_exe_fail   ${LANG_FRENCH} \
    "Certains fichiers de $0 n'ont pas été supprimés !$\r$\n\
     Ces fichiers doivent être supprimés manuellement."

#LangString str_msg_rm_root_fail  ${LANG_FRENCH} \
#    "ATTENTION : impossible de supprimer $\"$vim_install_root$\", \
#     il n'est pas vide !"

LangString str_msg_uninstalling  ${LANG_FRENCH} \
    "Désinstallation de l'ancienne version..."

LangString str_msg_registering   ${LANG_FRENCH} \
    "Enregistrement..."

LangString str_msg_unregistering ${LANG_FRENCH} \
    "Désenregistrement..."


##############################################################################
# Dialog Box                                                              {{{1
##############################################################################

LangString str_vimrc_page_title    ${LANG_FRENCH} \
    "Choisir les options de configuration de _vimrc"
LangString str_vimrc_page_subtitle ${LANG_FRENCH} \
    "Choisissez les paramètres de compatiblité, du clavier et de la souris."

LangString str_msg_compat_title    ${LANG_FRENCH} \
    " Comportement Vi / Vim "
LangString str_msg_compat_desc     ${LANG_FRENCH} \
    "&Compatibilité et améliorations"
LangString str_msg_compat_vi       ${LANG_FRENCH} \
    "Compatible Vi"
LangString str_msg_compat_vim      ${LANG_FRENCH} \
    "Vim d'origine"
LangString str_msg_compat_defaults ${LANG_FRENCH} \
    "Vim avec quelques améliorations (utiliser defaults.vim)"
LangString str_msg_compat_all      ${LANG_FRENCH} \
    "Toutes les améliorations (utiliser vimrc_example.vim) (Défaut)"

LangString str_msg_keymap_title   ${LANG_FRENCH} \
    " Raccourcis clavier "
LangString str_msg_keymap_desc    ${LANG_FRENCH} \
    "&Remapper des touches pour Windows (Ctrl-V, Ctrl-C, Ctrl-A, Ctrl-S, Ctrl-F, etc.)"
LangString str_msg_keymap_default ${LANG_FRENCH} \
    "Ne pas remapper les touches (Défaut)"
LangString str_msg_keymap_windows ${LANG_FRENCH} \
    "Remapper quelques touches"

LangString str_msg_mouse_title   ${LANG_FRENCH} \
    " Souris "
LangString str_msg_mouse_desc    ${LANG_FRENCH} \
    "&Comportement des boutons droit et gauche"
LangString str_msg_mouse_default ${LANG_FRENCH} \
    "Droit : menu contextuel, Gauche : mode visuel (Défaut)"
LangString str_msg_mouse_windows ${LANG_FRENCH} \
    "Droit : menu contextuel, Gauche : sélection (Windows)"
LangString str_msg_mouse_unix    ${LANG_FRENCH} \
    "Droit : étend la sélection, Gauche : mode visuel (Unix)"
