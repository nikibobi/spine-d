@echo off
dmd -lib -inline -O -release -odlib -ofspine-d.lib "spine\animation\animation.d" "spine\animation\package.d" "spine\animation\state\data.d" "spine\animation\state\state.d" "spine\animation\timeline\attachment.d" "spine\animation\timeline\color.d" "spine\animation\timeline\curve.d" "spine\animation\timeline\draworder.d" "spine\animation\timeline\event.d" "spine\animation\timeline\ffd.d" "spine\animation\timeline\flip.d" "spine\animation\timeline\flipx.d" "spine\animation\timeline\flipy.d" "spine\animation\timeline\ikconstraint.d" "spine\animation\timeline\rotate.d" "spine\animation\timeline\scale.d" "spine\animation\timeline\timeline.d" "spine\animation\timeline\translate.d" "spine\atlas\atlas.d" "spine\atlas\format.d" "spine\atlas\package.d" "spine\atlas\page.d" "spine\atlas\region.d" "spine\atlas\texture\filter.d" "spine\atlas\texture\loader.d" "spine\atlas\texture\wrap.d" "spine\attachment\atlasloader.d" "spine\attachment\attachment.d" "spine\attachment\boundingbox.d" "spine\attachment\loader.d" "spine\attachment\mesh.d" "spine\attachment\package.d" "spine\attachment\region.d" "spine\attachment\skinnedmesh.d" "spine\attachment\type.d" "spine\bone\bone.d" "spine\bone\data.d" "spine\bone\package.d" "spine\event\data.d" "spine\event\event.d" "spine\event\package.d" "spine\ikconstraint\data.d" "spine\ikconstraint\ikconstraint.d" "spine\ikconstraint\package.d" "spine\package.d" "spine\skeleton\data.d" "spine\skeleton\json.d" "spine\skeleton\package.d" "spine\skeleton\skeleton.d" "spine\skin\package.d" "spine\skin\skin.d" "spine\slot\blendmode.d" "spine\slot\data.d" "spine\slot\package.d" "spine\slot\slot.d" "spine\util\argnull.d" "spine\util\funct.d" "spine\util\init.d" "spine\util\package.d" "spine\util\property.d" "spine\util\vector.d"