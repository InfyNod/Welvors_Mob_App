abstract class AdmirersEvent {}

class LoadAdmirersData extends AdmirersEvent {}

class ChangeAdmirersTab extends AdmirersEvent {
  final String tab;
  ChangeAdmirersTab(this.tab);
}
