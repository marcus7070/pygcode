{
  description = "G-code parser for Python";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    pkgs0 = with import nixpkgs { system = "x86_64-linux"; }; pkgs;
    pythonOverrides = py-self: py-super: {
      pygcode = py-self.buildPythonPackage {

        pname = "pygcode";
        version = "202106";
        src = ./.;
        
        propagatedBuildInputs = with py-self; [
          euclid3
          six
        ];

        checkPhase = ''
          cd tests
          ${python.interpreter} -m unittest discover -s . -p 'test_*.py' --verbose
        '';

        pythonImportsCheck = [ "pygcode" ];

      };
      euclid3 = py-self.buildPythonPackage rec {

        pname = "euclid3";
        version = "0.01";

        src = py-self.fetchPypi {
          inherit pname version;
          sha256 = "sha256-JbgnpXrb/Zo/qGJeQ6vD6Qf2HeYiND5+U4SC75tG/Qs=";
        };

        pythonImportsCheck = [ "euclid3" ];

        meta = with pkgs0.lib; {
          description = "2D and 3D maths module for Python";
          homepage = "https://pypi.org/project/euclid3/";
          license = licenses.lgpl21;
          maintainers = with maintainers; [ marcus7070 ];
        };

      };
    };
    python = pkgs0.python3.override {
      packageOverrides = pythonOverrides;
      self = python;
    };
    pythonPkgs = pkgs0.python3.pkgs;

  in {
    packages.x86_64-linux.euclid3 = python.pkgs.euclid3;
    defaultPackage.x86_64-linux = python.withPackages (ps: [ ps.pygcode ] );
    overlays = { inherit pythonOverrides; };
  };
}
