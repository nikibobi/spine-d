@echo off
dmd -lib -inline -O -release -odlib -ofspine-d.lib "spine\d.d" "spine\animation\all.d" "spine\animation\animation.d" "spine\animation\state\data.d" "spine\animation\state\state.d" "spine\animation\timeline\attachment.d" "spine\animation\timeline\color.d" "spine\animation\timeline\curve.d" "spine\animation\timeline\draworder.d" "spine\animation\timeline\rotate.d" "spine\animation\timeline\scale.d" "spine\animation\timeline\timeline.d" "spine\animation\timeline\translate.d" "spine\atlas\all.d" "spine\atlas\atlas.d" "spine\atlas\format.d" "spine\atlas\page.d" "spine\atlas\region.d" "spine\atlas\texture\filter.d" "spine\atlas\texture\loader.d" "spine\atlas\texture\wrap.d" "spine\attachment\all.d" "spine\attachment\atlasloader.d" "spine\attachment\attachment.d" "spine\attachment\boundingbox.d" "spine\attachment\loader.d" "spine\attachment\region.d" "spine\attachment\type.d" "spine\bone\all.d" "spine\bone\bone.d" "spine\bone\data.d" "spine\skeleton\all.d" "spine\skeleton\data.d" "spine\skeleton\json.d" "spine\skeleton\skeleton.d" "spine\skin\all.d" "spine\skin\skin.d" "spine\slot\all.d" "spine\slot\data.d" "spine\slot\slot.d" "spine\util\all.d" "spine\util\argnull.d" "spine\util\funct.d" "spine\util\init.d" "spine\util\property.d" "spine\util\vector.d"