# src/game/Package.gd
extends Resource
class_name Package

## DADOS BASE PARA O JOGO
@export var package_name: String = "Encomenda Comum"
@export var recipient_apartment: String = "101" # O morador/apt para entrega

## DICAS/TEXTOS PARA O DIÁLOGO
@export_multiline var weight_description: String = "Parece leve. Talvez roupas?" # Dica para o diálogo
@export_multiline var surface_hint: String = "Caixa parda e sem marcas aparentes." # Dica para o diálogo

## CONFIGURAÇÃO DE EVENTO (O CERNE DA SUA MECÂNICA)
@export var is_creepy: bool = false # Se for a caixa do evento de creepy
@export var is_plot_critical: bool = false # Para pacotes como o do Evento 8
@export var creepy_scene_path: String = "" # Caminho para a cena de 'quebra de parede' (opcional para o MVP, pode ser uma TextureRect que aparece)
