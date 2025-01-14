//sealed class permite que seja feita a exaustão de opções como se fosse um enumerador. Uma sealed class não pode ser instanciada,
//extendida e somente implementada no mesmo arquivo. Dessa forma, o compilador sabe quais são todas as classes que implementam a sealed class
//permitindo que em um switch não seja necessário a cláusula default. Para o que está sendo proposto, o enum resolveria o problema em nosso app,
//mas será usado o sealed class apenas para mostrar uma forma alternativa. Quais são as vantagens?
//É possível colocar classes abstrataas que obrigatoriamente devem ser implementadas por que assina o contrato
sealed class DomainError {
  String description();
}

class UnexpectedError implements DomainError {
  @override
  String description() {
    return 'UnexpectedError was thrown';
  }
}

class SessionExpiredError implements DomainError {
  @override
  String description() {
    return 'SessionExpiredError was thrown';
  }
}
