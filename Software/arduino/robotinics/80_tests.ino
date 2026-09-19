// Teste funcional legado --------------------------------------------------

void TesteMovimento()
{
  mySerial.println("TESTE");

  CLS();
  Imprime(0, "Teste de Mov 1");
  Imprime(1, "Gira Cabeca");
  delay(1000);
  Cabeca.write(0); delay(1000);
  Cabeca.write(180); delay(1000);
  Cabeca.write(90); delay(1000);
  Cabeca.write(180); delay(1000);
  Cabeca.write(0); delay(1000);
  Cabeca.write(90); delay(1000);

  CLS(); Imprime(0, "Teste de Mov 2"); Imprime(1, "Lev. Braco Dir");
  BDireito.write(170); delay(1500);

  CLS(); Imprime(0, "Teste de Mov 3"); Imprime(1, "Lev. Braco Dir");
  BDireito.write(90); delay(1500);

  CLS(); Imprime(0, "Teste de Mov 4"); Imprime(1, "Abaixa Braco Dir");
  BDireito.write(10); delay(1500);
  MDireita.write(155);

  CLS(); Imprime(0, "Teste de Mov 5"); Imprime(1, "Gira Mao Dir");
  MDireita.write(10); delay(1500);

  CLS(); Imprime(0, "Teste de Mov 6"); Imprime(1, "Gira Mao Esq");
  BEsquerdo.write(2); delay(1500);

  CLS(); Imprime(0, "Teste de Mov 7"); Imprime(1, "Abaix Braco Dir");
  BDireito.write(0); delay(1500);
  MDireita.write(155);

  CLS(); Imprime(0, "Teste de Mov 8"); Imprime(1, "Gira Mao Esq");
  BEsquerdo.write(90); delay(1500);

  CLS(); Imprime(0, "Teste de Mov 9"); Imprime(1, "Abre GARRA Esq");
  GARRAESQ.write(150); delay(1500);

  CLS(); Imprime(0, "Teste de Mov 10"); Imprime(1, "Fecha GARRA Esq");
  GARRAESQ.write(7); delay(1500);

  CLS(); Imprime(0, "Teste de Mov 11"); Imprime(1, "Gira P Esq");
  PEsquerdo.write(0); delay(1500);

  CLS(); Imprime(0, "Teste de Mov 12"); Imprime(1, "Gira P Esq");
  PEsquerdo.write(90); delay(1500);
  PEsquerdo.write(180); delay(1500);
  PEsquerdo.write(90); delay(1500);

  CLS(); Imprime(0, "Teste de Mov 13"); Imprime(1, "Gira Mao Dir");
  MDireita.write(90); delay(1500);
  MDireita.write(155);

  CLS(); Imprime(0, "Teste de Mov 14"); Imprime(1, "Gira Mao Dir");
  MDireita.write(0); delay(1500);

  MDireita.write(155);
  BEsquerdo.write(166); delay(1500);
  BEsquerdo.write(2);
  BDireito.write(10); delay(1500);
  BEsquerdo.write(166);
  BDireito.write(10); delay(1500);
  BEsquerdo.write(2);
  BDireito.write(180); delay(1500);
  BEsquerdo.write(166);
  BDireito.write(10);

  CLS();
  Imprime(0, "Teste de Mov ");
  Imprime(1, "Fim de Teste");
}
