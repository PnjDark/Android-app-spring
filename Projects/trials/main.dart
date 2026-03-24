import 'package:flutter/material.dart';

// ==================== CLASS 01: DATA (One-liners) ====================
class S { const S(this.id, this.name); final String id, name; }
class A { const A(this.name, this.max, this.w); final String name; final double max, w; }
class G { const G(this.s, this.a, this.s1); final String s, a; final double? s1; }

// ==================== CLASS 03: EXTENSIONS ====================
extension on double {
  String get f => toStringAsFixed(1);
  String get l => this >= 90 ? 'A' : this >= 80 ? 'B' : this >= 70 ? 'C' : this >= 60 ? 'D' : 'F';
}

// ==================== CLASS 03: GENERIC + SCOPE ====================
double? grade(String student, List<A> asgn, List<G> grades) => asgn.fold<Map<String, double>>({}, (map, a) {
  final score = grades.firstWhere((g) => g.s == student && g.a == a.name, orElse: () => G(student, a.name, null)).s1 ?? 0.0;
  map[a.name] = score * a.w;
  return map;
}).values.let((values) => values.isEmpty ? null : values.reduce((a,b)=>a+b) / asgn.fold(0.0, (s,a)=>s+a.w) * 100);

extension on List<double> { T let<T>(T Function(List<double>) f) => f(this); }

// ==================== APP ====================
void main() => runApp(MaterialApp(home: _G()));

class _G extends StatefulWidget {
  @override
  State<_G> createState() => __G();
}

class __G extends State<_G> {
  final s = [S('S1', 'Alice'), S('S2', 'Bob')];
  final a = [A('HW1',100,.1), A('HW2',100,.1), A('Mid',100,.3), A('Final',100,.4)];
  var g = [G('S1','HW1',95), G('S1','HW2',88), G('S1','Mid',92), G('S1','Final',95), G('S2','HW1',85)];
  var selected = 'S1';
  double? r;
  
  void _calc() => setState(() => r = grade(selected, a, g));
  
  void _save(String name, double score) => setState(() {
    final i = g.indexWhere((x) => x.s == selected && x.a == name);
    i >= 0 ? g[i] = G(selected, name, score) : g.add(G(selected, name, score));
    _calc();
  });
  
  @override
  void initState() => super.initState().._calc();
  
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text('🎓 Grade')),
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Column(children: [
        DropdownButtonFormField(value: selected, items: s.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
          onChanged: (v) => setState(() => selected = v as String? ?? selected).._calc()),
        Expanded(child: ListView.builder(itemCount: a.length, itemBuilder: (_, i) {
          final x = a[i];
          final e = g.firstWhere((gg) => gg.s == selected && gg.a == x.name, orElse: () => G(selected, x.name, null)).s1;
          return Card(child: ListTile(title: Text('${x.name} (${(x.w*100).toInt()}%)'),
            trailing: SizedBox(width: 100, child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: e?.toString() ?? '0-${x.max}', border: OutlineInputBorder()),
              onSubmitted: (v) => double.tryParse(v)?.let((s) => s >=0 && s<=x.max ? _save(x.name, s) : null),
            )),
          ));
        })),
        if (r != null) Container(
          margin: EdgeInsets.only(top: 16), padding: EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [Text('${r!.f}%', style: TextStyle(fontSize: 48, color: Colors.white)), Text(r!.l, style: TextStyle(fontSize: 32, color: Colors.white))]),
        ),
      ]),
    ),
  );
}

extension on double? { void let(void Function(double) f) => this != null ? f(this!) : null; }