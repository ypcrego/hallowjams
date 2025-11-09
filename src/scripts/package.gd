# src/game/Package.gd
extends Resource
class_name Package

## DADOS BASE PARA O JOGO
@export var package_name: String
@export var recipient_apartment: String

## DICAS/TEXTOS PARA O DIÁLOGO
@export_multiline var weight_description: String
@export_multiline var surface_hint: String
@export_multiline var real_content: String

## CONFIGURAÇÃO DE EVENTO (O CERNE DA SUA MECÂNICA)
@export var is_creepy: bool = false # Se for a caixa do evento de creepy
@export var is_plot_critical: bool = false # Para pacotes como o do Evento 8
@export var creepy_scene_path: String = "" # Caminho para a cena de 'quebra de parede' (opcional para o MVP, pode ser uma TextureRect que aparece)
