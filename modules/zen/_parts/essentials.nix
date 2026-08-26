{containers, ...}: {
  pins = {
    "YouTube" = {
      id = "7454f1b5-22d5-4f48-9004-61f7c49ccdb3";
      container = containers.Personal.id;
      url = "https://youtube.com";
      isEssential = true;
      position = 101;
    };
    "Proton" = {
      id = "7a01d935-eaae-403f-9b7d-e0ec0904801f";
      container = containers.Personal.id;
      url = "https://mail.proton.me";
      isEssential = true;
      position = 102;
    };
    "Jelly" = {
      id = "513d0b0f-42e5-4c98-b180-619441698aef";
      container = containers.Personal.id;
      url = "https://jelly.jhofer.de";
      isEssential = true;
      position = 103;
    };
    "Karma" = {
      id = "ca83ba4d-167f-40ce-8284-160736e11019";
      container = containers.Personal.id;
      url = "https://karma.hla1.jhofer.lan";
      isEssential = true;
      position = 104;
    };
    "Matrix" = {
      id = "ffd131bf-5e7a-4e7f-b088-5261b0176c19";
      url = "https://app.element.io";
      container = containers.Personal.id;
      isEssential = true;
      position = 105;
    };
    "AI" = {
      id = "0c05d607-3880-4d49-a962-6804b6b0d502";
      url = "https://ai.jhofer.org/";
      container = containers.Personal.id;
      isEssential = true;
      position = 106;
    };
  };
}
