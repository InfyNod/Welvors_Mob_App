import 'dart:io';
void main() {
  Directory('assets').createSync(recursive: true);
  File('images:animation/Proposal.json').copySync('assets/Proposal.json');
}
