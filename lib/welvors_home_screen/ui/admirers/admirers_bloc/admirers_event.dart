abstract class AdmirersEvent {}

class LoadAdmirersData extends AdmirersEvent {}

class ChangeAdmirersTab extends AdmirersEvent {
  final String tab;
  ChangeAdmirersTab(this.tab);
}

class RemoveLike extends AdmirersEvent {
  final int id;
  RemoveLike(this.id);
}

class RemoveRose extends AdmirersEvent {
  final int id;
  RemoveRose(this.id);
}
