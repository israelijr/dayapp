class Historia {
  final int? id;
  final String userId;
  final String? assunto;
  final String titulo;
  final DateTime data;
  final String? tag;
  final String? descricao;
  final String? sentimento;
  final String? emoticon;
  final DateTime? dataCriacao;
  final DateTime? dataUpdate;
  final String? fotoHistoria;
  final String? grupo;
  final String? arquivado;
  final String? excluido;
  final DateTime? dataExclusao;

  Historia({
    this.id,
    required this.userId,
    this.assunto,
    required this.titulo,
    required this.data,
    this.tag,
    this.descricao,
    this.sentimento,
    this.emoticon,
    this.dataCriacao,
    this.dataUpdate,
    this.fotoHistoria,
    this.grupo,
    this.arquivado,
    this.excluido,
    this.dataExclusao,
  });

  factory Historia.fromMap(Map<String, dynamic> map) {
    return Historia(
      id: map['id'],
      userId: map['user_id'],
      assunto: map['assunto'],
      titulo: map['titulo'],
      data: DateTime.parse(map['data']),
      tag: map['tag'],
      descricao: map['descricao'],
      sentimento: map['sentimento'],
      emoticon: map['emoticon'],
      dataCriacao: map['data_criacao'] != null
          ? DateTime.tryParse(map['data_criacao'])
          : null,
      dataUpdate: map['data_update'] != null
          ? DateTime.tryParse(map['data_update'])
          : null,
      fotoHistoria: map['foto_historia'],
      grupo: map['grupo'],
      arquivado: map['arquivado'],
      excluido: map['excluido'],
      dataExclusao: map['data_exclusao'] != null
          ? DateTime.tryParse(map['data_exclusao'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'assunto': assunto,
      'titulo': titulo,
      'data': data.toIso8601String(),
      'tag': tag,
      'descricao': descricao,
      'sentimento': sentimento,
      'emoticon': emoticon,
      'data_criacao': dataCriacao?.toIso8601String(),
      'data_update': dataUpdate?.toIso8601String(),
      'foto_historia': fotoHistoria,
      'grupo': grupo,
      'arquivado': arquivado,
      'excluido': excluido,
      'data_exclusao': dataExclusao?.toIso8601String(),
    };
  }
}
