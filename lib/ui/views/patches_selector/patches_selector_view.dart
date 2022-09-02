import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:revanced_manager/theme.dart';
import 'package:revanced_manager/ui/views/patches_selector/patches_selector_viewmodel.dart';
import 'package:revanced_manager/ui/widgets/patchesSelectorView/patch_item.dart';
import 'package:revanced_manager/ui/widgets/shared/search_bar.dart';
import 'package:stacked/stacked.dart';

class PatchesSelectorView extends StatefulWidget {
  const PatchesSelectorView({Key? key}) : super(key: key);

  @override
  State<PatchesSelectorView> createState() => _PatchesSelectorViewState();
}

class _PatchesSelectorViewState extends State<PatchesSelectorView> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PatchesSelectorViewModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => PatchesSelectorViewModel(),
      builder: (context, model, child) => Scaffold(
        floatingActionButton: Visibility(
          visible: model.patches.isNotEmpty,
          child: FloatingActionButton.extended(
            label: I18nText('patchesSelectorView.doneButton'),
            icon: const Icon(Icons.check),
            onPressed: () {
              model.selectPatches();
              Navigator.of(context).pop();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.surface,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
            child: model.patches.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  )
                : Column(
                    children: <Widget>[
                      SearchBar(
                        showSelectIcon: true,
                        fillColor:
                            isDark ? const Color(0xff1B222B) : Colors.grey[200],
                        hintText: FlutterI18n.translate(
                          context,
                          'patchesSelectorView.searchBarHint',
                        ),
                        hintTextColor: Theme.of(context).colorScheme.tertiary,
                        onQueryChanged: (searchQuery) {
                          setState(() {
                            _query = searchQuery;
                          });
                        },
                        onSelectAll: (value) => model.selectAllPatches(value),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 80),
                          children: model
                              .getQueriedPatches(_query)
                              .map((patch) => PatchItem(
                                    name: patch.name,
                                    simpleName: patch.getSimpleName(),
                                    version: patch.version,
                                    description: patch.description,
                                    packageVersion: model.getAppVersion(),
                                    supportedPackageVersions:
                                        model.getSupportedVersions(patch),
                                    isUnsupported:
                                        !model.isPatchSupported(patch),
                                    isSelected: model.isSelected(patch),
                                    onChanged: (value) =>
                                        model.selectPatch(patch, value),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
